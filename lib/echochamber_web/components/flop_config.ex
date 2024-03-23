defmodule EchochamberWeb.FlopConfig do
  use Phoenix.Component

  def table_opts do
    [
      table_attrs: [class: "w-full border-collapse border border-slate-400"],
      thead_th_attrs: [class: "p-2 bg-gray-50 border border-slate-300"],
      tbody_td_attrs: [class: "p-2 border border-slate-300"]
    ]
  end

  def pagination_opts do
    assigns = %{}
    item = "flex items-center justify-center px-3 h-8 leading-tight border"
    hover = "hover:bg-black hover:text-white"

    normal =
      "text-gray-500 bg-white border-gray-300"

    current =
      "text-primary-600 bg-primary-50 hover:bg-primary-black hover:text-primary-700 border-primary-300"

    [
      current_link_attrs: [
        "aria-current": "page",
        class: ["z-10", item, current, hover]
      ],
      ellipsis_attrs: [
        class: ["text-gray-400", item, normal]
      ],
      ellipsis_content: ~H[<span class="cursor-default">…</span>],
      previous_link_attrs: [
        class: ["order-1 rounded-l-lg -mr-px ", item, normal, hover]
      ],
      previous_link_content:
        ~H[<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4">
  <path
    fill-rule="evenodd"
    d="M7.72 12.53a.75.75 0 0 1 0-1.06l7.5-7.5a.75.75 0 1 1 1.06 1.06L9.31 12l6.97 6.97a.75.75 0 1 1-1.06 1.06l-7.5-7.5Z"
    clip-rule="evenodd"
  />
</svg>],
      next_link_attrs: [
        class: ["order-3 rounded-r-lg", item, normal, hover]
      ],
      next_link_content:
        ~H[<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4">
  <path
    fill-rule="evenodd"
    d="M16.28 11.47a.75.75 0 0 1 0 1.06l-7.5 7.5a.75.75 0 0 1-1.06-1.06L14.69 12 7.72 5.03a.75.75 0 0 1 1.06-1.06l7.5 7.5Z"
    clip-rule="evenodd"
  />
</svg>],
      disabled_class: [
        "cursor-not-allowed !text-gray-300 hover:!bg-white"
      ],
      page_links: {:ellipsis, 3},
      pagination_link_aria_label: &"Go to page #{&1}",
      pagination_link_attrs: [
        class: [item, hover, normal]
      ],
      pagination_list_attrs: [class: "order-2 -mr-px inline-flex items-stretch -space-x-px"],
      wrapper_attrs: [class: "flex flex-nowrap w-fit"]
    ]
  end
end
