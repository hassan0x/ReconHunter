# Programming

## C Language

Hello World in C:
```c
#include <stdio.h>
main() {
    printf("Hello World\n");
}
```

Compile this code:
```
gcc main.c -o myprogram
```

### Data Types & Variables

Data types:
```c
int:     2, 5, 100
float:   1.5, 21.6, 100.5
char:    "s", "2", "$"
```

Variables:
```c
int    i, j, k;
char   c, ch;
float  salary;
```

Example:
```c
#include <stdio.h>
main() {
    int num1, num2;
    int result;

    num1 = 8;
    num2 = 4;

    result = num1 + num2;
    printf("The result is: %d \n", result);

    result = num1 - num2;
    printf("The result is: %d \n", result);

    result = num1 * num2;
    printf("The result is: %d \n", result);

    result = num1 / num2;
    printf("The result is: %d \n", result);
}
```

### IF Condition

IF:
```c
#include <stdio.h>
main() {
   int a = 10;

   if( a < 20 ) {
      printf("a is less than 20 \n" );
   }

   printf("value of a is : %d \n", a);
}
```

IF..else:
```c
#include <stdio.h>
main() {
    int a = 100;

    if( a < 20 ) {
        printf("a is less than 20\n" );
    }
    else {
        printf("a is not less than 20\n" );
    }

   printf("value of a is : %d\n", a);
}
```

### Loops

FOR:
```c
#include <stdio.h>
main() {
    int a;

    for( a=0; a<20; a++ ){
        printf("value of a: %d \n", a);
    }
}
```

While:
```c
#include <stdio.h>
main() {
    int a = 0;

    while( a < 20 ) {
        printf("value of a: %d \n", a);
        a++;
    }
}
```

### Simple Program

Write code to check if the student grade is greater than or equal 80% then print "you are special" 3 times.
```c
#include <stdio.h> 
main() { 
    int grade=50; 

    if (grade >= 80) {

        printf("Your grade is: %d \n", grade);
        for (int x=0; x<3; x++) {
            printf("You are special \n");
        }

    }
    else {
        printf("Your grade is: %d \n", grade);
        printf("You are not special \n");
    }
}
```

## Python Language

Hello World in Python:
```c
print "Hello World"
```

Run this code:
```
python code.py
```

### Basic Syntax

There is no data types in python:
```c
counter = 100
miles   = 1000.0
name    = "John"

print counter
print miles
print name
```

Example:
```c
num1 = 8
num2 = 4

result = num1 + num2
print "The result is: ", result

result = num1 - num2
print "The result is: ", result

result = num1 * num2
print "The result is: ", result

result = num1 / num2
print "The result is: ", result
```

### IF Condition

IF:
```c
a = 10

if a<20:
   print "a is less than 20"

print "value of a is: ", a
```

IF..else:
```c
a = 100

if a<20:
   print "a is less than 20"
else:
   print "a is not less than 20"

print "value of a is: ", a
```

### Loops

FOR:
```c
for a in range(0,20):
    print "value of a: ", a
```

While:
```c
a = 0
while a < 20 : 
    print "value of a: ", a
    a = a + 1
```

### Simple Program

Write code to check if the student grade is greater than or equal 80% then print "you are special" 3 times.

```c
grade=50

if grade>=80:
    print "Your grade is: ", grade
    for x in range(0,3):
        print "You are special"
else:
    print "Your grade is: ", grade
    print "You are not special"
```

### Lists

Lists:
```c
students = ["ahmed", "hassan", 12, 10.5, "$"]
for name in students:
    print name
```

Accessing values in lists:
```c
print students[0]
print students[1:4]
```

Updating lists:
```c
students[0] = "omar"
students.append("test")
students.remove("ahmed")
```

Example:
```c
grades = [80, 50, 12, 90, 95, 100 ,0]

for grade in grades:
    if grade >= 80:
        print "You are special, your grade is:", grade
    else:
        print "You are not special, your grade is:", grade
```

### Take data from user
```c
username = raw_input("enter your name: ")
```

### Simple Login Program

```c
print "Hello friends this is my first login program in python ..."
print "-----------------------------------------------------"

credentials = ["user1:passwd1","user2:passwd2","user3:passwd3"]

username = raw_input('Please enter your username: ')
password = raw_input('Please enter your password: ')

for credential in credentials:
    cred_user = credential.split(":")[0]
    cred_pass = credential.split(":")[1]

    if username == cred_user and password == cred_pass:
        print "You have logged in successfully."
        exit()

print "Login failed, please try again."
```

## HTML

HTML is used to define the layout and structure of the web pages.

```markup
<html>

<head>
    <title>HI i'm title</title>
</head>

<body>
    <h1 style="color:blue">big header or big word</h1>
    <p>normal sentense</p>
    <a href="https://www.google.com">click here to visit google</a>
    <script>
        alert("Hi i'm javascript.")
    </script>
</body>

</html>
```
Save file as anyname.html

### Forms

```markup
<html>

<body>

<form method="post" action="code.php">
    Username: <input type="text" name="username"><br>
    Password: <input type="password" name="password"><br>
    <input type="submit" value="submit">
</form>

</body>

</html>
```

## PHP Language

- To run php code you will need a web server.
- Web server is a software listens on TCP port 80 (HTTP), and its responsible to receive HTTP requests and send HTTP responses, you can think of the web server as the compiler of the language.
- Most common web servers apache, nginx, miscrosoft IIS.

```c
# Install apache server and php
apt-get install apache2 php7.0
```

### Basic Syntax

No data types like python.
The Arithmetic Operators like C and Python.

```c
<?php

$message = "Hello World!";
echo "$message <br>";

$num1 = 50;
$num2 = 20.5;

$result = $num1 + $num2;

echo "The result is: $result";

?>
```

### IF Conditions

IF:
```c
<?php
$a = 10;

if ($a<20) {
   echo "a is less than 20 <br>";
}

echo "value of a is: $a";
?>
```

IF..else:
```c
<?php
$a = 100;

if ($a<20) {
   echo "a is less than 20 <br>";
}
else {
   echo "a is not less than 20 <br>";
}

echo "value of a is: $a"
?>
```

### Loops

FOR:
```c
<?php

for($a=0;$a<20;$a++){
    echo "value of a: $a <br>";
}

?>
```

While:
```c
<?php

$a = 0;
while ($a < 20){ 
    echo "value of a: $a <br>";
    $a++;
}

?>
```

### Arrays

Arrays in PHP == Lists in Python
```c
<?php

$students = array("ahmed", "hassan", 12, 10.5, "$"); 
foreach ($students as $name) {
    echo "$name <br>";
}

$students[0] = "omar";
echo $students[0];

?>
```

### Simple Login Program (HTML)

```markup
<html>

<head>
    <title> Simple Login Page </title>
</head>

<body>

    <h1> HTML Forms </h1>

    <form method="post" action="code.php">
        Username: <input type="text" name="username"> <br>
        Password: <input type="password" name="password"> <br><br>
        <input type="submit" value="Login">
    </form>

    <p> If you click the "Login" button, the form-data will be sent to a page called "code.php" </p>

</body>

</html>
```

### Simple Login Program (PHP)

```c
<?php

$username = $_POST["username"];
$password = $_POST["password"];

$credentials = array("user1:passwd1", "user2:passwd2", "user3:passwd3");

foreach ($credentials as $credential) {

    $cred_user = explode(":", $credential)[0];
    $cred_pass = explode(":", $credential)[1];

    if ($username == $cred_user && $password == $cred_pass) {
        echo "You have logged in successfully";
        exit();
    }
}

echo "Login failed, please try again.";

?>
```
