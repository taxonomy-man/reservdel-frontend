import gleam/option.{type Option, None}

pub type Question {
  Question(
    id: Int,
    text: String,
    strategy: Strategy,
    is_terminal: Bool,
    visible: Bool,
    answer: Option(Answer),
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
      Strategy(Red, Green, Yellow),
      is_terminal: False,
      visible: True,
      answer: None,
    ),
    Question(
      2,
      "Har reservdelen hög omsättning?",
      Strategy(
        hold_in_stock: Yellow,
        buy_on_demand: Yellow,
        supplier_contract: Green,
      ),
      is_terminal: False,
      visible: False,
      answer: None,
    ),
    Question(
      3,
      "Finns behov av extern kompetens?",
      Strategy(
        hold_in_stock: Yellow,
        buy_on_demand: Red,
        supplier_contract: Green,
      ),
      is_terminal: False,
      visible: False,
      answer: None,
    ),
    Question(
      4,
      "Är tillåten stilleståndstid kortare än leveranstider?",
      Strategy(Green, Gray, Gray),
      is_terminal: True,
      visible: False,
      answer: None,
    ),
  ]
}
