---
title: Create a Script
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/fundamentals/coding-1/create-a-script
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, beginner, luau, variables, strings, print]
difficulty: beginner
---

# Create a Script

**Coding** is the process of creating instructions for computers to follow. Just like people use different languages, such as English and Spanish, so do programs. Roblox uses the coding language **Luau**.

This article will cover how to start coding in Roblox, introducing common concepts like scripts, data types, and variables. By the end, you'll be able to type out code that displays messages in Roblox Studio.

## Steps

### Code with scripts

In Roblox Studio, lines of Luau code are held in **scripts**. These scripts give the experience sets of instructions on how to give players health points, create a rain of fireballs, or anything else imaginable.

### Create a script

Scripts are commonly created in **ServerScriptService**, a special folder made just for holding scripts.

1. In Explorer, hover over **ServerScriptService** to see the **+** button.
2. Click the **+** button and select **Script**. A new script will be created and the script editor will open.
3. Right-click Script and select **Rename**. Name the script _PracticeScript_. Naming scripts helps you and any teammates remember what each script does.

### Hello world

New scripts include a print function at the top of the script editor. **Print functions** display text on the screen. It's one of the first functions many people learn, and you'll use it often. This code will make "Hello world!" appear on the screen.

```lua
print("Hello world!")
```

To find the script next time you open up Roblox Studio, click on the name of the script above the 3D viewport, or double-click the script's name in Explorer.

### Test output

You can see the result of running the default code with the **Output** window. If you've never used it before, you'll need to enable it.

1. From Studio's Window menu, open the Output window.
2. To test the script, initiate a playtest. `Hello world!` will show up in the output.
3. Click **Stop** to end the playtest. You can now return to the **Script** tab.

### Identify data types

Coding languages classify different kinds of values into **data types**. For example, one data type is a **number**. Number data types are self-explanatory as they are made up of only numbers.

Another data type is a **string**. Strings can hold numbers, letters, and characters. Take another look at the default code in the new script; the words and quotations within the parenthesis is an example of a **string** data type.

```lua
print("Hello world!")
```

Strings like `"Hello World"` always sit inside quotation marks, `"like this"`. More examples of strings are below. Notice how they hold a mix of letters and numbers.

- `"You just joined the game!"`
- `"There are 50 players left"`
- `"10"`

### Create variables

**Variables** are containers for information the program can use and change, like player names or points.

**Declaring** a variable is what coders call the process of creating a new variable. In Luau, to declare a new variable, type `local`, then type the name for the new variable. A variable that can hold a player name might look like: `local playerName`

> When declaring new variables, some coding languages require that you also state what data type the variable can use. For example, a variable in Java would be `String name = "Pavel"`. Luau only requires a name.

In Luau, variables can be global or local. You'll usually use **local** variables. Local variables can only be used within the script or chunk of code where they were created. Global variables can potentially be used by other scripts, but too many global variables can make your experience slow and unresponsive. It's better to stay in the habit of making variables local unless necessary.

### Use variables and strings together

Time to declare your own variables. These steps will use a string to store the name of your favorite animal.

1. Delete `print("Hello world!")`. It's best practice not to leave unnecessary code in your scripts.
2. Declare a new variable by first typing `local`, then naming the variable `myAnimal`.

```lua
local myAnimal
```

> **Warning:** Variable names can't include spaces. Be careful not to include spaces or the code won't work as intended.

### Name variables

Variables can be named anything, but good names will always describe their purpose. Generic names make your code difficult to read and update later. Coders will also use different capitalization styles to remind themselves how the variable is used within the script. A good default style is **camelCase**.

To write in camelCase:

- Begin with a lowercase letter
- Leave out spaces
- Capitalize additional words

**Good Variable Names:**
- `playerPoints`
- `numberStorageArray`

**Bad Variable Names:**
- `myVariable` - Doesn't describe the purpose of the variable
- `player name` - The included space will cause issues

### Assign values to variables

New variables are empty. To **assign** it a value, or put something inside its container, use the `=` symbol.

```lua
local myAnimal = "Porcupines"
```

### Use print() for your own messages

```lua
local myAnimal = "Porcupines"
print(myAnimal)
```

Test your code with the play button. You should see the name of your animal in the Output window.

### Combine strings

You can display any string in the Output using `print()`; you can even print multiple strings stored within variables or typed directly within the function. **Concatenation** is combining strings. To concatenate the string assigned to your variable and a second string, use two dots `..`.

```lua
local firstAnimal = "porcupines"
local secondAnimal = "dolphins"

print("I like " .. firstAnimal .. " and " .. secondAnimal)
```

## Key Concepts

- **Scripts**: Containers for Luau code, commonly in ServerScriptService
- **print()**: Displays text in the Output window
- **Data types**: Numbers and Strings are two fundamental types
- **Strings**: Text values in quotation marks
- **Variables**: Containers for information declared with `local`
- **Global vs local variables**: Prefer local
- **camelCase**: The naming convention
- **Concatenation**: Joining strings with `..`

## Code Snippets

```lua
-- Default hello world
print("Hello world!")

-- Variable with string
local myAnimal = "Porcupines"
print(myAnimal)

-- String concatenation
local firstAnimal = "porcupines"
local secondAnimal = "dolphins"
print("I like " .. firstAnimal .. " and " .. secondAnimal)
```

## Notes

- Scripts are commonly placed in **ServerScriptService**
- Variable names cannot include spaces
- Always prefer `local` variables over globals for performance
- Use the Output window to see script results and errors

## Source

Original URL: https://create.roblox.com/docs/tutorials/fundamentals/coding-1/create-a-script
Captured: 2026-04-16
