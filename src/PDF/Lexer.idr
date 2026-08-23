module PDF.Lexer

import PDF.Parser
import Data.List

public export
asciiByte : Char -> Bits8
asciiByte character = cast (ord character)

public export
asciiBytes : String -> List Bits8
asciiBytes text = map asciiByte (unpack text)

public export
bytesToString : List Bits8 -> String
bytesToString bytes = pack (map (chr . cast) bytes)

public export
matchAscii : String -> Parser ()
matchAscii text = matchBytes (asciiBytes text)

public export
isPdfWhitespace : Bits8 -> Bool
isPdfWhitespace byte =
  byte == 0 ||
  byte == 9 ||
  byte == 10 ||
  byte == 12 ||
  byte == 13 ||
  byte == 32

public export
isPdfDelimiter : Bits8 -> Bool
isPdfDelimiter byte =
  byte == asciiByte '(' ||
  byte == asciiByte ')' ||
  byte == asciiByte '<' ||
  byte == asciiByte '>' ||
  byte == asciiByte '[' ||
  byte == asciiByte ']' ||
  byte == asciiByte '{' ||
  byte == asciiByte '}' ||
  byte == asciiByte '/' ||
  byte == asciiByte '%'

public export
isDigitByte : Bits8 -> Bool
isDigitByte byte = byte >= asciiByte '0' && byte <= asciiByte '9'

public export
skipTrivia : Parser ()
skipTrivia = do
  skipWhileBytes isPdfWhitespace
  next <- peekByte
  case next of
    Just byte =>
      if byte == asciiByte '%'
        then do
          _ <- nextByte
          skipWhileBytes (\b => b /= asciiByte '\n' && b /= asciiByte '\r')
          skipTrivia
        else pure ()
    Nothing => pure ()

public export
pdfNatural : Parser Int
pdfNatural = do
  digits <- takeWhileBytes isDigitByte
  case digits of
    [] => failParse "expected decimal integer"
    _ => pure (foldl addDigit 0 digits)
  where
    addDigit : Int -> Bits8 -> Int
    addDigit value byte = value * 10 + (cast byte - ord '0')

public export
pdfName : Parser String
pdfName = do
  matchByte (asciiByte '/')
  raw <- takeWhileBytes (\byte => not (isPdfWhitespace byte) && not (isPdfDelimiter byte))
  pure (bytesToString raw)

public export
pdfHeader : Parser (Int, Int)
pdfHeader = do
  matchAscii "%PDF-"
  major <- satisfy "PDF major version digit" isDigitByte
  matchByte (asciiByte '.')
  minor <- satisfy "PDF minor version digit" isDigitByte
  pure (cast major - ord '0', cast minor - ord '0')

public export
indirectObjectHeader : Parser (Int, Int)
indirectObjectHeader = do
  skipTrivia
  objectNumber <- pdfNatural
  skipTrivia
  generationNumber <- pdfNatural
  skipTrivia
  matchAscii "obj"
  pure (objectNumber, generationNumber)
