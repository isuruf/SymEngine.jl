
type DenseMatrix
    ptr::Ptr{Void}
end

typealias Matrix DenseMatrix

function DenseMatrix(m::UInt, n::UInt)
    z = DenseMatrix(ccall((:dense_matrix_new_rows_cols, libsymengine), Ptr{Void}, (UInt, UInt), m, n))
    finalizer(z, dense_matrix_free)
    return z
end

DenseMatrix() = DenseMatrix(0, 0)

function DenseMatrix(m::UInt, n::UInt, v::CVecBasic)
    z = DenseMatrix(ccall((:dense_matrix_new_vec, libsymengine), Ptr{Void}, (UInt, UInt, Ptr{Void}), m, n, v.ptr))
    finalizer(z, dense_matrix_free)
    return z
end

dense_matrix_free(b::DenseMatrix) = ccall((:dense_matrix_free, libsymengine), Void, (Ptr{Void}, ), b.ptr)

DenseMatrix(y::Tuple{Integer, Integer}) = DenseMatrix(y[1], y[2])
DenseMatrix(a::Integer, b::Integer) = DenseMatrix(convert(UInt, a), convert(UInt, b))
DenseMatrix(a::Integer, b::Integer, v::CVecBasic) = DenseMatrix(convert(UInt, a), convert(UInt, b), v)

function DenseMatrix{T}(v::Array{T, 2})
    vec = CVecBasic()
    rows, cols = size(v)
    for i = 1:rows
        for j = 1:cols
            push!(vec, v[i, j])
        end
    end
    DenseMatrix(rows, cols, vec)
end

function Base.getindex(s::DenseMatrix, n::Culong, m::Culong)
    result = Basic()
    ccall((:dense_matrix_get_basic, libsymengine), Void, (Ptr{Basic}, Ptr{Void}, Culong, Culong), &result, s.ptr, n - 1, m - 1)
    result
end

Base.getindex(s::DenseMatrix, n::Integer, m::Integer) = Base.getindex(s, convert(Culong, n), convert(Culong, m))

function Base.setindex!(s::DenseMatrix, b::Basic, n::Culong, m::Culong)
    ccall((:dense_matrix_set_basic, libsymengine), Void, (Ptr{Void}, Culong, Culong, Ptr{Basic}), s.ptr, n - 1, m - 1, &b)
end

Base.setindex!(s::DenseMatrix, b::Basic, n::Integer, m::Integer) = Base.setindex!(s, b, convert(Culong, n), convert(Culong, m))

function Base.size(s::DenseMatrix)
    rows = ccall((:dense_matrix_rows, libsymengine), Culong, (Ptr{Void}, ), s.ptr)
    cols = ccall((:dense_matrix_cols, libsymengine), Culong, (Ptr{Void}, ), s.ptr)
    (rows, cols)
end

function Base.length(s::DenseMatrix)
    rows, cols = Base.size(s)
    rows * cols
end

function LU(s::DenseMatrix)
    l = DenseMatrix()
    u = DenseMatrix()
    ccall((:dense_matrix_LU, libsymengine), Void, (Ptr{Void}, Ptr{Void}, Ptr{Void}), l.ptr, u.ptr, s.ptr)
    return l, u
end
    
