# -*- coding: utf-8 -*-

module FirebirdDB

export connect, close

immutable Firebird
  dsn::ASCIIString
end

function connect(dsn::ASCIIString, usr::ASCIIString, pwd::ASCIIString,
  charset::ASCIIString="UTF8")
  return Firebird(dsn)
end

function close(cn)
  return true
end

end
