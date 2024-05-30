pub type Question {
  Question(
    id: Int,
    text: String,
    strategy: Strategy,
    is_terminal: Bool,
    visible: Bool,
    answered: Bool,
  )
}

pub type Answer {
  Yes
  No
}

pub type Strategy {
  Strategy(hold_in_stock: Grade, buy_on_demand: Grade, supplier_contract: Grade)
}

pub type Grade {
  Red
  Yellow
  Green
  White
  Gray
}

pub fn get_questions() {
  [
    Question(
      1,
      "Är reservdelen dyr?",
      Strategy(Green, Red, Yellow),
      is_terminal: False,
      visible: True,
      answered: False,
    ),
    Question(
      2,
      "Har reservdelen hög omsättning?",
      Strategy(
        hold_in_stock: Yellow,
        buy_on_demand: Yellow,
        supplier_contract: Red,
      ),
      is_terminal: False,
      visible: False,
      answered: False,
    ),
    Question(
      3,
      "Är tillåten stilleståndstid kortare än leveranstider?",
      Strategy(Green, Red, Red),
      is_terminal: True,
      visible: False,
      answered: False,
    ),
  ]
}
