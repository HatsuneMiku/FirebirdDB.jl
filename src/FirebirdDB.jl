# -*- coding: utf-8 -*-
# FirebirdDB

VERSION >= v"0.4.0-dev+6521" && __precompile__()
module FirebirdDB

export FB_API_HANDLE, ISC_DB_HANDLE, ISC_TR_HANDLE, Firebird
export connect, close, in_transaction

const FBCLIENT = @windows ? :fbclient : :libfbclient

const ISC_STATUS_LENGTH = 20
const ISC_STATUS_ARRAY_SIZE = ISC_STATUS_LENGTH * 8 * sizeof(UInt)

typealias FB_API_HANDLE Ptr{Void}
typealias ISC_DB_HANDLE FB_API_HANDLE
typealias ISC_TR_HANDLE FB_API_HANDLE

typealias XSQLDA Void

immutable Firebird
  stat::Array{UInt8, 1}
  tr::Array{ISC_TR_HANDLE, 1} # must be initialized with [C_NULL]
  cn::Array{ISC_DB_HANDLE, 1} # must be initialized with [C_NULL]
  dsn::ASCIIString
  usr::ASCIIString
  pwd::ASCIIString
  charset::ASCIIString
end

function Firebird(dsn::ASCIIString, usr::ASCIIString, pwd::ASCIIString,
  charset::ASCIIString="UTF8")
  return Firebird(Array(UInt8, ISC_STATUS_ARRAY_SIZE), [C_NULL], [C_NULL],
    dsn, usr, pwd, charset)
end

function pr_error(stat::Array{UInt8, 1}, ope::AbstractString, result::Any)
  println("[")
  println(@sprintf "PROBLEM ON '%s'." ope)
  ccall((:isc_print_status, FBCLIENT), Void, (Ptr{UInt8},), stat)
  c = ccall((:isc_sqlcode, FBCLIENT), UInt, (Ptr{UInt8},), stat)
  println(@sprintf "SQLCODE: %08x" c)
  println("]")
  return result
end

function connect(dsn::ASCIIString, usr::ASCIIString, pwd::ASCIIString,
  charset::ASCIIString="UTF8")
  fb = Firebird(dsn, usr, pwd, charset)
  r = ccall((:isc_attach_database, FBCLIENT), Bool,
    (Ptr{UInt8}, UInt16, Ptr{UInt8}, Ptr{Ptr{Void}}, UInt16, Ptr{UInt8}),
    fb.stat, 0, [fb.dsn.data; [0x00]], fb.cn, 0, C_NULL)
  if r || (fb.cn[1] == C_NULL)
    return pr_error(fb.stat, "attach database", nothing)
  end
  return fb
end

function close(fb::Firebird)
  r = ccall((:isc_detach_database, FBCLIENT), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}),
    fb.stat, fb.cn)
  if r || (fb.cn[1] != C_NULL)
    return pr_error(fb.stat, "detach database", false)
  end
  return !r
end

function in_transaction(fb::Firebird, s::AbstractString)
  r = ccall((:isc_start_transaction, FBCLIENT), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}, UInt16, Ptr{Ptr{Void}}, UInt16, Ptr{UInt8}),
    fb.stat, fb.tr, 1, fb.cn, 0, C_NULL)
  r && return pr_error(fb.stat, "in: start transaction", false)
  # for ss in split(s, "\n") # to handle SubString convert(UTF8String, ss).data
    r = ccall((:isc_dsql_execute_immediate, FBCLIENT), Bool,
      (Ptr{UInt8}, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}, UInt16,
        Ptr{UInt8}, UInt16, Ptr{XSQLDA}),
      fb.stat, fb.cn, fb.tr, 0, [s.data; [0x00]], 1, C_NULL)
    r && return pr_error(fb.stat,
      (@sprintf "in: dsql execute immediate\n [%s]" s), false)
  # end
  r = ccall((:isc_commit_transaction, FBCLIENT), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}),
    fb.stat, fb.tr)
  r && return pr_error(fb.stat, "in: commit transaction", false)
  return true
end

end
