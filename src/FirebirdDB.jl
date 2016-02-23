# -*- coding: utf-8 -*-

module FirebirdDB

export FB_API_HANDLE, ISC_DB_HANDLE, ISC_TR_HANDLE, Firebird
export connect, close

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

function pr_error(stat::Array{UInt8, 1}, ope::ASCIIString, result::Any)
  println("[")
  println(@sprintf "PROBLEM ON '%s'." ope)
  ccall((:isc_print_status, :fbclient), Void, (Ptr{UInt8},), stat)
  c = ccall((:isc_sqlcode, :fbclient), UInt, (Ptr{UInt8},), stat)
  println(@sprintf "SQLCODE: %08x" c)
  println("]")
  return result
end

function connect(dsn::ASCIIString, usr::ASCIIString, pwd::ASCIIString,
  charset::ASCIIString="UTF8")
  fb = Firebird(dsn, usr, pwd, charset)
  r = ccall((:isc_attach_database, :fbclient), Bool,
    (Ptr{UInt8}, UInt16, Ptr{UInt8}, Ptr{Ptr{Void}}, UInt16, Ptr{UInt8}),
    fb.stat, 0, fb.dsn.data, fb.cn, 0, C_NULL)
  if r || (fb.cn[1] == C_NULL)
    return pr_error(fb.stat, "attach database", nothing)
  end
  return fb
end

function close(fb::Firebird)
  r = ccall((:isc_detach_database, :fbclient), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}),
    fb.stat, fb.cn)
  if r || (fb.cn[1] != C_NULL)
    return pr_error(fb.stat, "detach database", false)
  end
  return !r
end

function cleanup(fb::Firebird)
  r = ccall((:isc_start_transaction, :fbclient), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}, UInt16, Ptr{Ptr{Void}}, UInt16, Ptr{UInt8}),
    fb.stat, fb.tr, 1, fb.cn, 0, C_NULL)
  r && return pr_error(fb.stat, "cleanup: start transaction", false)
  r = ccall((:isc_dsql_execute_immediate, :fbclient), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}, UInt16,
      Ptr{UInt8},
      UInt16, Ptr{XSQLDA}),
    fb.stat, fb.cn, fb.tr, 0,
      "delete from ttest where c2 in ('abc', 'def', 'xyz');",
      1, C_NULL)
  r && return pr_error(fb.stat, "cleanup: dsql execute immediate", false)
  r = ccall((:isc_commit_transaction, :fbclient), Bool,
    (Ptr{UInt8}, Ptr{Ptr{Void}}),
    fb.stat, fb.tr)
  r && return pr_error(fb.stat, "cleanup: commit transaction", false)
  return true
end

end
