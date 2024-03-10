def camel(camel_case): 
    new_str = ""
    for i in camel_case: 
        new_str += i
        if i.isupper(): 
            new_str += "_" + i.lower()
        print(new_str)
        


while True: 
    camel_case = input("CamelCase: ")
    if camel_case.isalpha(): 
        camel(camel_case)
        break