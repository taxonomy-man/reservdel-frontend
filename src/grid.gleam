import questions

pub fn grid_view(questions: List(Question)) -> element.Element(Msg) {
  let headers = [
    "Question", "Hold in Stock", "Buy on Demand", "Supplier Contract",
  ]

  let header_elements =
    headers
    |> list.map(fn(header) {
      html.div([attribute.class("p-2 border border-gray-200")], [
        element.text(header),
      ])
    })

  let row_elements =
    questions
    |> list.map(fn(question) {
      let cells = [
        question.text,
        grade_to_color_string(question.yes_options.hold_in_stock),
        grade_to_color_string(question.yes_options.buy_on_demand),
        grade_to_color_string(question.yes_options.supplier_contract),
      ]

      cells
      |> list.map(fn(cell) {
        html.div([attribute.class("p-2 border border-gray-200")], [
          element.text(cell),
        ])
      })
    })

  let grid_elements = list.append(header_elements, list.flatten(row_elements))

  html.div([attribute.class("grid grid-cols-4 gap-4")], grid_elements)
}

fn grade_to_color_string(grade: Grade) -> String {
  case grade {
    Red -> "red"
    Yellow -> "yellow"
    Green -> "green"
  }
}
