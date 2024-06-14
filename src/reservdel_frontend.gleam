import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import state.{
  type Answer, type Grade, type Question, Gray, Green, No, Red, White, Yellow,
  Yes,
}

@external(javascript, "./test.mjs", "console_log_1")
pub fn console_log(str: String) -> Nil

@external(javascript, "./test.mjs", "animateElement")
pub fn animate_element(id: String) -> Nil

pub type Model =
  List(Question)

pub fn to_string(model: Model) -> String {
  model
  |> list.map(fn(question) {
    "\n------------------\n"
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
    <> ", answer: "
    <> answer_to_string(question.answer)
  })
  |> string.join(", ")
}

pub fn grade_to_string(grade: Grade) -> String {
  case grade {
    Red -> "Red"
    Yellow -> "Yellow"
    Green -> "Green"
    White -> "White"
    Gray -> "Gray"
  }
}

pub fn answer_to_string(answer: Option(Answer)) -> String {
  case answer {
    Some(Yes) -> "Yes"
    Some(No) -> "No"
    None -> "None"
  }
}

fn init(_flags) -> Model {
  state.get_questions()
}

pub type Msg {
  ToggleVisibility(q_nr: Int, ans: Answer)
  Reset
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    ToggleVisibility(q_nr, ans) -> toggle_visibility(model, q_nr, ans)
    Reset -> init(Nil)
  }
}

pub fn toggle_visibility(
  model: List(Question),
  q_nr: Int,
  ans: Answer,
) -> List(Question) {
  console_log(model |> to_string)
  model
  |> list.map(fn(question) {
    case question.id == q_nr {
      True ->
        case ans {
          Yes -> state.Question(..question, visible: True, answer: Some(Yes))
          No -> state.Question(..question, visible: True, answer: Some(No))
        }
      False -> state.Question(..question, visible: True)
    }
  })
}

pub fn grid(model: Model) -> element.Element(Msg) {
  // Check if any terminal question has been answered Yes
  let terminal_yes_answered =
    model
    |> list.any(fn(question) {
      question.is_terminal && question.answer == Some(Yes)
    })

  let question_elements =
    model
    |> list.filter(fn(question) { question.visible })
    |> list.map(fn(question) {
      // If a terminal question has Yes and this is not the terminal question, show gray cells

      let grade_cells = case terminal_yes_answered && !question.is_terminal {
        True -> ["bg-gray-300"]
        False -> [
          grade_to_color_class(question.strategy.hold_in_stock),
          grade_to_color_class(question.strategy.buy_on_demand),
          grade_to_color_class(question.strategy.supplier_contract),
        ]
      }

      let strategy_row = case question.answer {
        Some(Yes) ->
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
        Some(No) ->
          grade_cells
          |> list.map(fn(cell) {
            html.div(
              [
                attribute.class(
                  "p-2 border border-gray-200 h-10 w-full bg-white",
                ),
              ],
              [],
            )
          })
        None -> []
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

  let reset_button =
    html.button(
      [
        attribute.class(
          "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-1 rounded",
        ),
        event.on_click(Reset),
      ],
      [element.text("återställ")],
    )

  let all_questions_answered =
    list.all(model, fn(question) { question.visible && question.answer != None })

  let elements = case all_questions_answered {
    True -> list.append(question_elements, [reset_button])
    False -> question_elements
  }

  html.div([attribute.class("space-y-2")], elements)
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
