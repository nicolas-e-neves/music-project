return {
   dataversion = 0.0,
   Name = "Demo 2",

   {"clef", "G"},
   {"key", 0},
   {"time-signature", 4, 4},
   {"tempo", 120},

   ---------- 1

   {"note", 60, 0.5},
   {"note", nil, 0.5},
   {"note", 64, 0.5},
   {"note", nil, 0.5},
   
   {"start-group"},
   {"note", 67, 0.5},
   {"note", 69, 0.5},
   {"note", 71, 0.5},
   {"note", 72, 0.5},
   {"end-group"},

   ---------- 2

   {"note", 72, 0.5},
   {"note", nil, 0.5},
   {"note", 76, 0.5},
   {"note", nil, 0.5},

   {"start-group"},
   {"note", 79, 0.5},
   {"note", 81, 0.5},
   {"note", 83, 0.5},
   {"note", 84, 0.5},
   {"end-group"},

   ---------- 3

   {"start-group"},
   {"note", 60, 0.25},
   {"note", 62, 0.25},
   {"note", 64, 0.25},
   {"note", 65, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 67, 0.25},
   {"note", 69, 0.25},
   {"note", 71, 0.25},
   {"note", 72, 0.25},
   {"end-group"},

   ---------- 4

   {"start-group"},
   {"note", 72, 0.25},
   {"note", 74, 0.25},
   {"note", 76, 0.25},
   {"note", 77, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 79, 0.25},
   {"note", 81, 0.25},
   {"note", 83, 0.25},
   {"note", 84, 0.25},
   {"end-group"},

   ---------- 5

   {"start-group"},
   {"note", 60, 0.5},
   {"note", 60, 0.25},
   {"note", 62, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 64, 0.5},
   {"note", 64, 0.25},
   {"note", 65, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 67, 0.5},
   {"note", 67, 0.25},
   {"note", 69, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 71, 0.5},
   {"note", 71, 0.25},
   {"note", 72, 0.25},
   {"end-group"},

   ---------- 6

   {"start-group"},
   {"note", 74, 0.5},
   {"note", 74, 0.25},
   {"note", 76, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 77, 0.5},
   {"note", 77, 0.25},
   {"note", 79, 0.25},
   {"end-group"},

   {"start-group"},
   {"note", 81, 0.5},
   {"note", 81, 0.25},
   {"note", 83, 0.25},
   {"end-group"},

   {"note", 84, 1},
}