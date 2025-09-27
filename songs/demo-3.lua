return {
   dataversion = 1.0,

   title = "Demo 3",
   subtitle = "Treble and Bass Clefs",
   authors = {"Nícolas Neves"},

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
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {67}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {67, 72, 76}, accidentals = {0}},

                  {type = "note", duration = 0.5, pitches = {69}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {74}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {67}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {72}, accidentals = {0}},

                  {type = "note", duration = 0.5, pitches = {69}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {74}, accidentals = {0}},
                  {type = "end-group"},

               },
            },
         },
         [2] = {                 --> Measure 2
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },

            content = {
               [1] = {           --> Voice 1
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {55}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {60, 64, 67}, accidentals = {0, 0, 0}},

                  {type = "note", duration = 0.5, pitches = {53}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {57}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {55}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {60}, accidentals = {0}},

                  {type = "note", duration = 0.5, pitches = {53}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {57}, accidentals = {0}},
                  {type = "end-group"},

               },
            },
         }
      },
   }
}