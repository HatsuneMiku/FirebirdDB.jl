# -*- coding: utf-8 -*-

module FirebirdDB

export connect, close

const ISC_STATUS_LENGTH = 20
const ISC_STATUS_ARRAY_SIZE = ISC_STATUS_LENGTH * 8 * sizeof(UInt)

immutable Firebird
  dsn::ASCIIString
end

function pr_error(stat::Array{UInt8, 1}, ope::ASCIIString)
  println("[")
  println(@sprintf "PROBLEM ON '%s'." ope)
  ccall((:isc_print_status, :fbclient), Void, (Ptr{UInt8},), stat)
  c = ccall((:isc_sqlcode, :fbclient), UInt, (Ptr{UInt8},), stat)
  println(@sprintf "SQLCODE: %08x" c)
  println("]")
  return true
end

function connect(dsn::ASCIIString, usr::ASCIIString, pwd::ASCIIString,
  charset::ASCIIString="UTF8")
  cn = Array{UInt, 1}([0]) # must set 0
  stat = Array(UInt8, ISC_STATUS_ARRAY_SIZE)
  r = ccall((:isc_attach_database, :fbclient),
    Bool, (Ptr{UInt8}, UInt16, Ptr{UInt8}, Ptr{UInt}, UInt16, Ptr{UInt8}),
    stat, 0, dsn.data, cn, 0, C_NULL)
  (r || (cn[1] == 0)) && (pr_error(stat, "attach database"); return nothing)
  return cn # Firebird(dsn)
end

function close(cn)
  stat = Array(UInt8, ISC_STATUS_ARRAY_SIZE)
  r = ccall((:isc_detach_database, :fbclient),
    Bool, (Ptr{UInt8}, Ptr{Void}),
    stat, pointer(cn))
  return !r
end

end
