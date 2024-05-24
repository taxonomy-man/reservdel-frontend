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

pub fn grade_to_string(grade: Grade) {
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

pub fn update(model: Model, msg) -> Model {
  let state = toggle_visibility(model, msg)
  console_log(to_string(state))
  state
}

pub fn toggle_visibility(model: Model, msg: Msg) -> Model {
  console_log("toggle_visibility, id: " <> int.to_string(msg.q_nr))
  model
  |> list.map(fn(question) {
    case question.id == msg.q_nr {
      True -> state.Question(..question, id: msg.q_nr + 1, visible: True)
      False -> question
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
            [attribute.class("p-2 border border-gray-200 h-10 " <> cell)],
            [],
          )
        })

      let question_row =
        html.div([attribute.class("flex items-center space-x-4")], [
          html.div([attribute.class("p-2 border border-gray-200 flex-1")], [
            element.text(question.text),
          ]),
          html.input([
            attribute.type_("button"),
            attribute.name("visibility"),
            attribute.class("p-2 border border-gray-200 text-white rounded"),
            event.on_click(ToggleVisibility(question.id, yes: True)),
          ]),
        ])

      html.div([attribute.class("space-y-2")], [
        question_row,
        html.div([attribute.class("flex space-x-4")], strategy_row),
      ])
    })

  html.div([attribute.class("space-y-4")], question_elements)
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
