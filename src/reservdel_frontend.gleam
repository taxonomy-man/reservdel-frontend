import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import state.{type Grade, type Question}

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
  })
  |> string.join(", ")
}

pub fn grade_to_string(grade: Grade) -> String {
  case grade {
    state.Red -> "Red"
    state.Yellow -> "Yellow"
    state.Green -> "Green"
  }
}

fn init(_flags) -> Model {
  state.get_questions()
}

pub type Msg {
  ToggleVisibility(q_nr: Int, yes: Bool)
}

pub fn update(model: Model, msg: Msg) -> Model {
  let state = toggle_visibility(model, msg)
  console_log(to_string(state))
  state
}

pub fn toggle_visibility(model: List(Question), msg: Msg) -> List(Question) {
  console_log("toggle_visibility, id: " <> int.to_string(msg.q_nr))
  model
  |> list.map(fn(question) {
    let next_id = msg.q_nr + 1
    case question.id {
      _ if msg.q_nr == question.id -> state.Question(..question, visible: True)
      _ if next_id == question.id -> state.Question(..question, visible: True)
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

      let strategy_row =
        grade_cells
        |> list.map(fn(cell) {
          html.div(
            [attribute.class("p-2 border border-gray-200 h-10 w-full " <> cell)],
            [],
          )
        })
      let _ =
        animate_element(
          question.id
          |> int.to_string,
        )
      let question_row =
        html.div([attribute.class("flex items-center space-x-4 mx-auto")], [
          // Removed 'flex-1' class
          html.div([attribute.class("p-2 border border-gray-200 mr-2")], [
            // Added 'mr-4' class for margin
            element.text(question.text),
          ]),
          html.button(
            [
              attribute.name("visibility"),
              attribute.class(
                "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-1 rounded",
              ),
              event.on_click(ToggleVisibility(question.id, yes: True)),
            ],
            [element.text("Ja")],
          ),
          html.button(
            [
              attribute.name("visibility"),
              attribute.class(
                "bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-1 rounded",
              ),
              event.on_click(ToggleVisibility(question.id, yes: False)),
            ],
            [element.text("Nej")],
          ),
        ])

      html.div([attribute.class("space-y-2 mx-auto")], [
        // Added 'mx-auto' class for centering
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
