module PDF.Parser

import Data.List
import Data.Vect

public export
data ParseError = ParseError Nat String

public export
errorOffset : ParseError -> Nat
errorOffset (ParseError offset _) = offset

public export
errorMessage : ParseError -> String
errorMessage (ParseError _ message) = message

export
Eq ParseError where
  (ParseError leftOffset leftMessage) == (ParseError rightOffset rightMessage) =
    leftOffset == rightOffset && leftMessage == rightMessage

export
Show ParseError where
  show (ParseError offset message) =
    "byte offset " ++ show offset ++ ": " ++ message

public export
data ParseState = ParseState (List Bits8) Nat

public export
remaining : ParseState -> List Bits8
remaining (ParseState bytes _) = bytes

public export
offset : ParseState -> Nat
offset (ParseState _ position) = position

public export
data Parser : Type -> Type where
  MkParser : (ParseState -> Either ParseError (a, ParseState)) -> Parser a

public export
runParser : Parser a -> ParseState -> Either ParseError (a, ParseState)
runParser (MkParser parser) = parser

public export
parseWithRest : Parser a -> List Bits8 -> Either ParseError (a, List Bits8)
parseWithRest parser bytes =
  case runParser parser (ParseState bytes 0) of
    Left error => Left error
    Right (value, state) => Right (value, remaining state)

public export
parse : Parser a -> List Bits8 -> Either ParseError a
parse parser bytes =
  case parseWithRest parser bytes of
    Left error => Left error
    Right (value, _) => Right value

export
Functor Parser where
  map function (MkParser parser) = MkParser $ \state =>
    case parser state of
      Left error => Left error
      Right (value, nextState) => Right (function value, nextState)

export
Applicative Parser where
  pure value = MkParser $ \state => Right (value, state)

  (MkParser functionParser) <*> (MkParser valueParser) = MkParser $ \state =>
    case functionParser state of
      Left error => Left error
      Right (function, nextState) =>
        case valueParser nextState of
          Left error => Left error
          Right (value, finalState) => Right (function value, finalState)

export
Monad Parser where
  (MkParser parser) >>= next = MkParser $ \state =>
    case parser state of
      Left error => Left error
      Right (value, nextState) => runParser (next value) nextState

public export
failParse : String -> Parser a
failParse message = MkParser $ \state =>
  Left (ParseError (offset state) message)

public export
ensure : Bool -> String -> Parser ()
ensure True _ = pure ()
ensure False message = failParse message

public export
getState : Parser ParseState
getState = MkParser $ \state => Right (state, state)

public export
getOffset : Parser Nat
getOffset = map offset getState

public export
peekByte : Parser (Maybe Bits8)
peekByte = MkParser $ \state =>
  case remaining state of
    [] => Right (Nothing, state)
    byte :: _ => Right (Just byte, state)

public export
nextByte : Parser Bits8
nextByte = MkParser $ \state =>
  case state of
    ParseState [] position =>
      Left (ParseError position "end of input")
    ParseState (byte :: rest) position =>
      Right (byte, ParseState rest (S position))

public export
satisfy : String -> (Bits8 -> Bool) -> Parser Bits8
satisfy expectation predicate = MkParser $ \state =>
  case state of
    ParseState [] position =>
      Left (ParseError position ("expected " ++ expectation ++ ", found end of input"))
    ParseState (byte :: rest) position =>
      if predicate byte
        then Right (byte, ParseState rest (S position))
        else Left (ParseError position ("expected " ++ expectation ++ ", found byte " ++ show byte))

public export
matchByte : Bits8 -> Parser ()
matchByte expected = do
  _ <- satisfy ("byte " ++ show expected) (== expected)
  pure ()

public export
matchBytes : List Bits8 -> Parser ()
matchBytes [] = pure ()
matchBytes (byte :: rest) = do
  matchByte byte
  matchBytes rest

public export
takeBytes : (count : Nat) -> Parser (Vect count Bits8)
takeBytes Z = pure []
takeBytes (S count) = do
  byte <- nextByte
  rest <- takeBytes count
  pure (byte :: rest)

public export
takeWhileBytes : (Bits8 -> Bool) -> Parser (List Bits8)
takeWhileBytes predicate = MkParser $ \state =>
  let (taken, rest) = span predicate (remaining state)
      consumed = length taken
  in Right (taken, ParseState rest (offset state + consumed))

public export
skipWhileBytes : (Bits8 -> Bool) -> Parser ()
skipWhileBytes predicate = map (const ()) (takeWhileBytes predicate)

public export
endOfInput : Parser ()
endOfInput = do
  next <- peekByte
  case next of
    Nothing => pure ()
    Just byte => failParse ("expected end of input, found byte " ++ show byte)
