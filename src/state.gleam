pub type Question {
  Question(text: String, yes_options: Strategy, is_terminal: Bool)
}

pub type Strategy {
  Strategy(hold_in_stock: Grade, buy_on_demand: Grade, supplier_contract: Grade)
}

pub type Grade {
  Red
  Yellow
  Green
}

pub fn get_questions() {
  [
    Question(
      "Är reservdelen dyr?",
      Strategy(Green, Red, Yellow),
      is_terminal: False,
    ),
    Question(
      "Har reservdelen hög omsättning?",
      Strategy(
        hold_in_stock: Yellow,
        buy_on_demand: Yellow,
        supplier_contract: Red,
      ),
      is_terminal: False,
    ),
    Question(
      "Är tillåten stilleståndstid kortare än leveranstider?",
      Strategy(Green, Red, Red),
      is_terminal: True,
    ),
  ]
}
