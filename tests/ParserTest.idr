module Main

import PDF.Parser
import PDF.Lexer
import System

headerTest : Bool
headerTest =
  parse pdfHeader (asciiBytes "%PDF-1.7\n") == Right (1, 7)

objectHeaderTest : Bool
objectHeaderTest =
  parse indirectObjectHeader (asciiBytes "\n% comment\n12 0 obj\n") == Right (12, 0)

fixedLengthTest : Bool
fixedLengthTest =
  case parseWithRest (takeBytes 3) [10, 20, 30, 40] of
    Right ([10, 20, 30], [40]) => True
    _ => False

shortReadTest : Bool
shortReadTest =
  case runParser (takeBytes 3) (ParseState [10, 20] 0) of
    Left (ParseError 2 "end of input") => True
    _ => False

nameTest : Bool
nameTest =
  parse pdfName (asciiBytes "/Subtype /Image") == Right "Subtype"

absoluteOffsetTest : Bool
absoluteOffsetTest =
  case parseAt 200 (takeBytes 2) [10] of
    Left (ParseError 201 "end of input") => True
    _ => False

main : IO ()
main =
  if headerTest && objectHeaderTest && fixedLengthTest && shortReadTest && nameTest && absoluteOffsetTest
    then putStrLn "parser tests: ok"
    else die "parser tests: failed"
