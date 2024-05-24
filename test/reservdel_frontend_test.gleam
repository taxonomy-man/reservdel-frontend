import gleam/list
import gleeunit
import gleeunit/should

//import reservdel_frontend.{set_visible}
import state.{type Grade, Question, Strategy}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn set_visible_test() {
  let questions = [
    Question(
      1,
      "Är reservdelen dyr?",
      Strategy(state.Green, state.Red, state.Yellow),
      is_terminal: False,
      visible: False,
    ),
    Question(
      2,
      "Har reservdelen hög omsättning?",
      Strategy(
        hold_in_stock: state.Red,
        buy_on_demand: state.Yellow,
        supplier_contract: state.Green,
      ),
      is_terminal: False,
      visible: False,
    ),
  ]

  let updated_questions = questions
  //set_visible(questions)
}
