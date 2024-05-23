import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http

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
  todo
}

pub fn view(model: Model) -> element.Element(Msg) {
  let count = int.to_string(model)
  html.div([attribute.class("bg-purple-500 text-white p-4 rounded-lg")], [
    element.text(count),
  ])

  html.div([attribute.class("bg-pink-500 text-white p-4 rounded-lg")], [
    html.h1([attribute.class("text-4xl font-bold")], [
      element.text("Counter" <> count),
    ]),
    html.div([], [element.text("This is a simple counter app")]),
    html.div([], [
      html.div([], [
        html.button(
          [
            event.on_click(Increment),
            attribute.class("bg-blue-500 text-white p-2 rounded-lg"),
          ],
          [element.text("+")],
        ),
      ]),
    ]),
    html.div([], [
      html.div([], [
        html.button(
          [
            event.on_click(Decrement),
            attribute.class("bg-red-500 text-white p-2 rounded-lg"),
          ],
          [element.text("-")],
        ),
      ]),
    ]),
  ])
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
