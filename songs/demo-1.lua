return {
   dataversion = 1.0,

   title = "Demo 1",
   subtitle = "",
   authors = {""},

   systems = {
      [1] = { -- System 1
         [1] = { -- Measure 1
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {60}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {62}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {64}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {65}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {67}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {69}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {71}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {72}, accidentals = {0}},
                  {type = "end-group"},
               },
            },
         },
         [2] = { -- Measure 2
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {72}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {74}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {76}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {77}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {79}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {81}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {83}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {84}, accidentals = {0}},
                  {type = "end-group"},
               },
            },
         },
         [3] = { -- Measure 3
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {60}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {60}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {62}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {62}, accidentals = {1}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {64}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {65}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {65}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {67}, accidentals = {0}},
                  {type = "end-group"},
               },
            },
         },
         [4] = { -- Measure 4
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {67}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {69}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {69}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {71}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {72}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {72}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {74}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {74}, accidentals = {1}},
                  {type = "end-group"},
               },
            },
         },
         [5] = { -- Measure 5
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {76}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {77}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {77}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {79}, accidentals = {0}},
                  {type = "end-group"},

                  {type = "start-group"},
                  {type = "note", duration = 0.5, pitches = {79}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {81}, accidentals = {0}},
                  {type = "note", duration = 0.5, pitches = {81}, accidentals = {1}},
                  {type = "note", duration = 0.5, pitches = {83}, accidentals = {0}},
                  {type = "end-group"},
               },
            },
         },
         [6] = { -- Measure 6
            info = {
               clef = "G",
               key = 0,
               time = {4, 4},
               tempo = 120,
            },
            content = {
               [1] = {
                  {type = "note", duration = 4, pitches = {84}, accidentals = {0}},
               },
            },
         },
      },
   }
}