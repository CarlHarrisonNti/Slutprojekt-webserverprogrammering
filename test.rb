OPERATORS = {"+" => ->(x,y){x+y}, "-" => ->(x,y){x-y}, "*" => ->(x,y){x*y}, "/" => ->(x,y){x/y}}

p OPERATORS["-"].call(1,2)