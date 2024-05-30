import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import state.{type Answer, type Grade, type Question, type Strategy, No, Yes}

@external(javascript, "./test.mjs", "console_log_1")
pub fn console_log(str: String) -> Nil

@external(javascript, "./test.mjs", "animateElement")
pub fn animate_element(id: String) -> Nil

pub type Model =
  List(Question)

pub fn to_string(model: Model) -> String {
  model
  |> list.map(fn(question) {
    "\n"
    <> "text: "
    <> question.text
    <> ", id: "
    <> int.to_string(question.id)
    <> ", visible: "
    <> bool.to_string(question.visible)
    <> ", hold_in_stock: "
    <> grade_to_string(question.strategy.hold_in_stock)
    <> ", buy_on_demand: "
    <> grade_to_string(question.strategy.buy_on_demand)
    <> ", supplier_contract: "
    <> grade_to_string(question.strategy.supplier_contract)
  })
  |> string.join(", ")
}

pub fn grade_to_string(grade: Grade) -> String {
  case grade {
    state.Red -> "Red"
    state.Yellow -> "Yellow"
    state.Green -> "Green"
    state.White -> "White"
    state.Gray -> "Gray"
  }
}

fn init(_flags) -> Model {
  state.get_questions()
}

pub type Msg {
  ToggleVisibility(q_nr: Int, ans: Answer)
}

pub fn update(model: Model, msg: Msg) -> Model {
  let state = toggle_visibility(model, msg)
  console_log(to_string(state))
  state
}

pub fn question_answered(msg: Msg, question: Question) -> Bool {
  msg.q_nr == question.id
}

pub fn toggle_visibility(model: List(Question), msg: Msg) -> List(Question) {
  console_log("toggle_visibility, id: " <> int.to_string(msg.q_nr))
  let terminal_answered: Bool =
    list.any(model, fn(question: Question) {
      question.is_terminal && question_answered(msg, question)
    })
  model
  |> list.map(fn(question) {
    let is_answered = question_answered(msg, question)
    let next_id = msg.q_nr + 1
    case question.id {
      _ if is_answered && question.is_terminal ->
        // If the question is a terminal question and it's answered, keep its grades that are green, others turn gray
        state.Question(
          ..question,
          visible: True,
          answered: True,
          strategy: state.Strategy(
            hold_in_stock: case question.strategy.hold_in_stock {
              state.Green -> state.Green
              _ -> state.Gray
            },
            buy_on_demand: case question.strategy.buy_on_demand {
              state.Green -> state.Green
              _ -> state.Gray
            },
            supplier_contract: case question.strategy.supplier_contract {
              state.Green -> state.Green
              _ -> state.Gray
            },
          ),
        )
      _ if terminal_answered ->
        // If any terminal question is answered, set all other questions' grades to gray and make them visible
        state.Question(
          ..question,
          visible: True,
          strategy: state.Strategy(
            hold_in_stock: state.Gray,
            buy_on_demand: state.Gray,
            supplier_contract: state.Gray,
          ),
        )
      _ if is_answered && msg.ans == Yes ->
        // If the question is answered with "yes" and it's the current question, set the next question's visibility to True
        state.Question(..question, visible: True, answered: True)
      _ if is_answered && msg.ans == No ->
        // If the question is answered with "no", set its grades to white and make it visible
        state.Question(
          ..question,
          visible: True,
          answered: True,
          strategy: state.Strategy(
            hold_in_stock: state.White,
            buy_on_demand: state.White,
            supplier_contract: state.White,
          ),
        )
      _ if question.id == next_id ->
        // If the question is the next question, set its visibility to True
        state.Question(..question, visible: True)
      _ -> question
    }
  })
}

pub fn grid(model: Model) -> element.Element(Msg) {
  let question_elements =
    model
    |> list.filter(fn(question) { question.visible })
    |> list.map(fn(question) {
      let grade_cells = [
        grade_to_color_class(question.strategy.hold_in_stock),
        grade_to_color_class(question.strategy.buy_on_demand),
        grade_to_color_class(question.strategy.supplier_contract),
      ]

      // Always show the strategy row if the question is answered, regardless of the answer being yes or no
      let strategy_row = case question.answered {
        True ->
          grade_cells
          |> list.map(fn(cell) {
            html.div(
              [
                attribute.class(
                  "p-2 border border-gray-200 h-10 w-full " <> cell,
                ),
              ],
              [],
            )
          })
        False -> []
      }

      let question_row =
        html.div([attribute.class("flex items-center space-x-4 mx-auto")], [
          html.div([attribute.class("p-2 border border-gray-200 mr-2")], [
            element.text(question.text),
          ]),
          html.button(
            [
              attribute.name("visibility"),
              attribute.class(
                "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-1 rounded",
              ),
              event.on_click(ToggleVisibility(question.id, ans: state.Yes)),
            ],
            [element.text("Ja")],
          ),
          html.button(
            [
              attribute.name("visibility"),
              attribute.class(
                "bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-1 rounded",
              ),
              event.on_click(ToggleVisibility(question.id, ans: state.No)),
            ],
            [element.text("Nej")],
          ),
        ])

      html.div([attribute.class("space-y-2 mx-auto")], [
        question_row,
        html.div([attribute.class("flex space-x-4")], strategy_row),
      ])
    })

  html.div([attribute.class("space-y-2")], question_elements)
}

fn grade_to_color_class(grade: Grade) -> String {
  case grade {
    state.Red -> "bg-red-500"
    state.Yellow -> "bg-yellow-300"
    state.Green -> "bg-green-500"
    state.White -> "bg-white"
    state.Gray -> "bg-gray-200"
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [grid(model)])
}

pub fn main() {
  console_log(
    init(Nil)
    |> to_string,
  )
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
