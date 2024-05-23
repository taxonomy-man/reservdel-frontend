import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import state.{type Grade, type Question}

@external(javascript, "./test.mjs", "console_log_1")
pub fn console_log(str: String) -> a

pub type Model =
  List(Question)

fn init(_flags) -> Model {
  state.init_state()
}

pub type Msg {
  ToggleVisibility(q_nr: Int, yes: Bool)
}

pub fn update(model: Model, msg) -> Model {
  toggle_visibility(model, msg)
}

pub fn toggle_visibility(model: Model, msg: Msg) -> Model {
  console_log("toggle_visibility, id: " <> int.to_string(msg.q_nr))
  model
  |> list.map(fn(question) {
    case question.id == msg.q_nr {
      True -> state.Question(..question, visible: !question.visible)
      False -> question
    }
  })
}

pub fn grid(model: Model) -> element.Element(Msg) {
  let headers = [
    "Fråga", "Visa", "Ha på lager", "Köpa vid behov", "Leverantörsavtal",
  ]

  let header_elements =
    headers
    |> list.map(fn(header) {
      html.div([attribute.class("p-2 border border-gray-200")], [
        element.text(header),
      ])
    })

  let row_elements =
    model
    |> list.filter(fn(question) { question.visible })
    |> list.map(fn(question) {
      let grade_cells = [
        grade_to_color_class(question.yes_options.hold_in_stock),
        grade_to_color_class(question.yes_options.buy_on_demand),
        grade_to_color_class(question.yes_options.supplier_contract),
      ]

      let cells =
        grade_cells
        |> list.map(fn(cell) {
          html.div(
            [attribute.class("p-2 border border-gray-200 h-10 " <> cell)],
            [],
          )
        })

      let question_cell =
        html.div([attribute.class("p-2 border border-gray-200")], [
          element.text(question.text),
        ])

      let radio_button =
        html.input([
          attribute.type_("radio"),
          attribute.name("visibility"),
          event.on_click(ToggleVisibility(question.id, yes: True)),
        ])

      list.append([question_cell, radio_button], cells)
    })

  let grid_elements = list.append(header_elements, list.flatten(row_elements))

  html.div([attribute.class("grid grid-cols-5 gap-4")], grid_elements)
}

fn grade_to_color_class(grade: Grade) -> String {
  case grade {
    state.Red -> "bg-red-500"
    state.Yellow -> "bg-yellow-500"
    state.Green -> "bg-green-500"
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [grid(model)])
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
