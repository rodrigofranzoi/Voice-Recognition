## Voice recognition app

Languages available: 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🇧🇷 🇩🇪

Note: the commands will change according with the langugage.

## Objectives

With this application you can generate data simply using voice commands.

## Rules

You have four commands:

* code: accepts numbers from 0 to 9 as parameter
* count: accepts numbers from 0 to 9 as parameter
* back: remove the last entry on the data array and the actual buffer
* reset: clean the actual buffer

## How to use

1. Allow the app to use micrphone 🎤 so we can hear you 👀
2. Allow the app to use speech functionality
3. Click `Start speech`
4. Now you can say `count, code, back, reset` and numbers from 0 to 9
5. The last command will appear on the green circle in the middle the screen
6. The buffer of parameters are located on the green square. It means the values allocated for the current last given command.
7. You can always check your inputs clicking on `History` button. You can say commands ands parameters while in the history screen.
8. When you are done, click stop to save your last command.


#### Example 1: 

Sequence of commands: `["code", "1", "2", "5", "count", "1", "count", "5", "1"]` **program stopped**
Expected data: 
```json
[ 
    {
        "command": "code"
        "value": "125",
    },
    {
        "command": "count"
        "value": "1",
    },
    {
        "command": "count"
        "value": "51",
    }
]
```

#### Example 2: 

Sequence of commands: `["code", "2", "5", "count", "1", ""]` **program stopped**
Expected data: 
```json
[ 
    {
        "command": "code"
        "value": "25",
    },
    {
        "command": "count"
        "value": "1",
    }
]
```

#### Example **Reset** command: 

Sequence of commands: `["code", "9", "6", "8", "count", "1", "count" "9", "5", "reset"]` **program stopped**
Expected data: 
```json
[ 
    {
        "command": "code"
        "value": "968",
    },
    {
        "command": "count"
        "value": "1",
    }
]
```

**Current buffer erased**

#### Example **Back** command: 

Sequence of commands: `["code",  "8", "count", "1", "count" "9", "5", "back"]` **program stopped**
Expected data: 
```json
[ 
    {
        "command": "code"
        "value": "8",
    }
]
```

**Current buffer erased and last entry removed**

## Demo

[![DEMO](https://img.youtube.com/vi/PYJKEo0J6qw/0.jpg)](https://www.youtube.com/watch?v=PYJKEo0J6qw)

More details [here](./Resources/Mobile-application.pdf)