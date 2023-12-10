


`import sys`
`import time`

fn main {

    var m:# = TrafficLight()
    var data = m.marshal()
    m = None

    loop var x = 0; x < 10; x = x + 1 {
        m = TrafficLight.unmarshal(data)
        m.tick()
        time.sleep(1)
        data = m.marshal()
        m = nil
    }
}

#[derive(marshal)]
#TrafficLight

    -interface-

    tick

    -machine-

    $Green
        |>|
            print("Green") ^

        |tick|
            -> $Yellow ^

    $Yellow
        |>|
            print("Yellow") ^

        |tick|
            -> $Red ^

    $Red
         |>|
            print("Red") ^

        |tick|
            -> $Green ^

##
