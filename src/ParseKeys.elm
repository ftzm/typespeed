module ParseKeys exposing (keyToChar)

import Keyboard.Extra exposing (..)


keyToChar : Bool -> Key -> Maybe Char
keyToChar shift k =
    case shift of
        True ->
            case k of
                CharA ->
                    Just 'A'

                CharB ->
                    Just 'B'

                CharC ->
                    Just 'C'

                CharD ->
                    Just 'D'

                CharE ->
                    Just 'E'

                CharF ->
                    Just 'F'

                CharG ->
                    Just 'G'

                CharH ->
                    Just 'H'

                CharI ->
                    Just 'I'

                CharJ ->
                    Just 'J'

                CharK ->
                    Just 'K'

                CharL ->
                    Just 'L'

                CharM ->
                    Just 'M'

                CharN ->
                    Just 'N'

                CharO ->
                    Just 'O'

                CharP ->
                    Just 'P'

                CharQ ->
                    Just 'Q'

                CharR ->
                    Just 'R'

                CharS ->
                    Just 'S'

                CharT ->
                    Just 'T'

                CharU ->
                    Just 'U'

                CharV ->
                    Just 'V'

                CharW ->
                    Just 'W'

                CharX ->
                    Just 'X'

                CharY ->
                    Just 'Y'

                CharZ ->
                    Just 'Z'

                Space ->
                    Just ' '

                Colon ->
                    Just ':'

                Slash ->
                    Just '?'

                Quote ->
                    Just '"'

                Number0 ->
                    Just ')'

                Number1 ->
                    Just '!'

                Number2 ->
                    Just '@'

                Number3 ->
                    Just '#'

                Number4 ->
                    Just '$'

                Number5 ->
                    Just '%'

                Number6 ->
                    Just '^'

                Number7 ->
                    Just '&'

                Number8 ->
                    Just '*'

                Number9 ->
                    Just '('

                Semicolon ->
                    Just ':'

                HyphenMinus ->
                    Just '_'

                Subtract ->
                    Just '_'

                Minus ->
                    Just '_'

                _ ->
                    Nothing

        False ->
            case k of
                CharA ->
                    Just 'a'

                CharB ->
                    Just 'b'

                CharC ->
                    Just 'c'

                CharD ->
                    Just 'd'

                CharE ->
                    Just 'e'

                CharF ->
                    Just 'f'

                CharG ->
                    Just 'g'

                CharH ->
                    Just 'h'

                CharI ->
                    Just 'i'

                CharJ ->
                    Just 'j'

                CharK ->
                    Just 'k'

                CharL ->
                    Just 'l'

                CharM ->
                    Just 'm'

                CharN ->
                    Just 'n'

                CharO ->
                    Just 'o'

                CharP ->
                    Just 'p'

                CharQ ->
                    Just 'q'

                CharR ->
                    Just 'r'

                CharS ->
                    Just 's'

                CharT ->
                    Just 't'

                CharU ->
                    Just 'u'

                CharV ->
                    Just 'v'

                CharW ->
                    Just 'w'

                CharX ->
                    Just 'x'

                CharY ->
                    Just 'y'

                CharZ ->
                    Just 'z'

                Number0 ->
                    Just '0'

                Number1 ->
                    Just '1'

                Number2 ->
                    Just '2'

                Number3 ->
                    Just '3'

                Number4 ->
                    Just '4'

                Number5 ->
                    Just '5'

                Number6 ->
                    Just '6'

                Number7 ->
                    Just '7'

                Number8 ->
                    Just '8'

                Number9 ->
                    Just '9'

                Semicolon ->
                    Just ';'

                Slash ->
                    Just '/'

                Space ->
                    Just ' '

                Quote ->
                    Just '\''

                Period ->
                    Just '.'

                Comma ->
                    Just ','

                HyphenMinus ->
                    Just '-'

                Subtract ->
                    Just '-'

                Minus ->
                    Just '-'

                _ ->
                    Nothing
