@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - admin@tubakaya.com}

module Tests

@memo value setUp() {
        return "something";
}

test bool Test1() {
        myData = setUp();
        
        return true;
}

test bool Test2() {
        myData = setUp();

        return true;
}

test bool Test3() {
        myData = setUp();

        return false;
}