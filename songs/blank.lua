return {
   dataversion = 1.0,

   title = "Blank",
   subtitle = "No Music Here",
   authors = {"Author Name"},

   systems = {
      [1] = {                    --> System 1
         [1] = {                 --> Measure 1
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },

            content = {
               [1] = {           --> Voice 1
                  {type = "note", duration = 1, pitches = {60, 64, 67}, accidentals = {0, 0, 0}, articulation = {}}, -- new syntax for creating notes
               },
            },
         },
      },
   }
}