# types from SymEngine to Julia
## CSetBasic
type CSetBasic
    ptr::Ptr{Void}
end

function CSetBasic()
    z = CSetBasic(ccall((:setbasic_new, libsymengine), Ptr{Void}, ()))
    finalizer(z, CSetBasic_free)
    z
end

function CSetBasic_free(x::CSetBasic)
    if x.ptr != C_NULL
        ccall((:setbasic_free, libsymengine), Void, (Ptr{Void},), x.ptr)
        x.ptr = C_NULL
    end
end

function Base.length(s::CSetBasic)
    ccall((:setbasic_size, libsymengine), UInt, (Ptr{Void},), s.ptr)
end

function Base.getindex(s::CSetBasic, n::Cuint)
    result = Basic()
    ccall((:setbasic_get, libsymengine), Void, (Ptr{Void}, Cuint, Ptr{Basic}), s.ptr, n - 1, &result)
    result
end

Base.getindex(s::CSetBasic, n::Integer) = Base.getindex(s, convert(Cuint, n))

function Base.convert(::Type{Vector}, x::CSetBasic)
    n = Base.length(x)
    [x[i] for i in 1:n]
end
Base.convert(::Type{Set}, x::CSetBasic) = Set(convert(Vector, x))

## VecBasic Need this for get_args...

type CVecBasic
    ptr::Ptr{Void}
end

function CVecBasic()
    z = CVecBasic(ccall((:vecbasic_new, libsymengine), Ptr{Void}, ()))
    finalizer(z, CVecBasic_free)
    z
end

function CVecBasic_free(x::CVecBasic)
    if x.ptr != C_NULL
        ccall((:vecbasic_free, libsymengine), Void, (Ptr{Void},), x.ptr)
        x.ptr = C_NULL
    end
end

function Base.push!(x::CVecBasic, y::Basic)
    ccall((:vecbasic_push_back, libsymengine), Void, (Ptr{Void}, Ptr{Basic}), x.ptr, &y)
end

Base.push!(x::CVecBasic, y::Number) = Base.push!(x, convert(Basic, y))

function Base.length(s::CVecBasic)
    ccall((:vecbasic_size, libsymengine), UInt, (Ptr{Void},), s.ptr)
end

function Base.getindex(s::CVecBasic, n::Cuint)
    result = Basic()
    ccall((:vecbasic_get, libsymengine), Void, (Ptr{Void}, Cuint, Ptr{Basic}), s.ptr, n - 1, &result)
    result
end

Base.getindex(s::CVecBasic, n::Integer) = Base.getindex(s, convert(Cuint, n))

function Base.convert(::Type{Vector}, x::CVecBasic)
    n = Base.length(x)
    [x[i] for i in 1:n]
end

function CVecBasic(x::Array)
    z = CVecBasic()
    for I in eachindex(x)
        push!(z, getindex(x, I))
    end
    z
end

Base.convert(::Type{CVecBasic}, x::Array) = CVecBasic(x)

