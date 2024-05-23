import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import state.{type Grade, type Question}

pub type Model =
  Int

fn init(_flags) -> Model {
  0
}

pub type Msg {
  Increment
  Decrement
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Increment -> model + 1
    Decrement -> model - 1
  }
}

pub fn grid(model: Model) -> element.Element(Msg) {
  let headers = [
    "Fråga", "Ha på lager", "Köpa vid behov", "Leverantörsavtal",
  ]

  let header_elements =
    headers
    |> list.map(fn(header) {
      html.div([attribute.class("p-2 border border-gray-200")], [
        element.text(header),
      ])
    })

  let row_elements =
    state.get_questions()
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

      list.append(
        [
          html.div([attribute.class("p-2 border border-gray-200")], [
            element.text(question.text),
          ]),
        ],
        cells,
      )
    })

  let grid_elements = list.append(header_elements, list.flatten(row_elements))

  html.div([attribute.class("grid grid-cols-4 gap-4")], grid_elements)
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
