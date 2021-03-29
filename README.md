#String Primitives and Macros in MASM

This program includes macros mGetString to display a prompt and get a string from the user and mDisplayString to display a string. The ReadVal procedure uses mGetString to convert a value entered by the user from a string of ascii characters to its signed numerical value and validates that it is a valid SDWORD. The WriteVal procedure converts an SDWORD numerical value to a string of ascii characters and displays it with mDisplayString.

In main, the intro procedure displays the program title, name of the author, and instructions for the users and then calls procedures getIntegers and displayResults to test ReadVal and WriteVal. getIntegers calls ReadVal to get 10 integers from the users and stores them in an array. Then, displayResults displays the list of integers, their sum, and their rounded average. Finally, the showGoodbye procedure displays a parting message.
