module Cars exposing
    ( Cars
    , add
    , cars1
    , cars2
    , cars3
    , cars4
    , cars6
    , cars8
    , init
    , sub
    )


type Cars
    = Cars Int


carsTotal : Int
carsTotal =
    45


type Error
    = MoreThenTotal
    | LessThenZero


add : Cars -> Cars -> Result Error Cars
add (Cars a) (Cars b) =
    let
        result =
            a + b
    in
    if result > carsTotal then
        Err MoreThenTotal

    else
        Ok (Cars result)


sub : Cars -> Cars -> Result Error Cars
sub (Cars a) (Cars b) =
    let
        result =
            a - b
    in
    if result < 0 then
        Err LessThenZero

    else
        Ok (Cars result)


init : Cars
init =
    Cars 45


cars1 : Cars
cars1 =
    Cars 1


cars2 : Cars
cars2 =
    Cars 2


cars3 : Cars
cars3 =
    Cars 3


cars4 : Cars
cars4 =
    Cars 4


cars6 : Cars
cars6 =
    Cars 6


cars8 : Cars
cars8 =
    Cars 8
