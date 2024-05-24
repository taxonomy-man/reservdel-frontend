pub type Question {
  Question(
    id: Int,
    text: String,
    strategy: Strategy,
    is_terminal: Bool,
    visible: Bool,
  )
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
      1,
      "Är reservdelen dyr?",
      Strategy(Green, Red, Yellow),
      is_terminal: False,
      visible: True,
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
    ),
    Question(
      3,
      "Är tillåten stilleståndstid kortare än leveranstider?",
      Strategy(Green, Red, Red),
      is_terminal: True,
      visible: False,
    ),
  ]
}
