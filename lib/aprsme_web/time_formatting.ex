defmodule AprsmeWeb.TimeFormatting do
  @spec format_ts(
          {{integer, pos_integer, pos_integer},
           {non_neg_integer, non_neg_integer, non_neg_integer}
           | {non_neg_integer, non_neg_integer, non_neg_integer,
              non_neg_integer | {char, 0 | 1 | 2 | 3 | 4 | 5 | 6}}}
          | {integer, pos_integer, pos_integer}
          | %{
              :__struct__ => Date | DateTime | NaiveDateTime | Time,
              :calendar => atom,
              optional(:day) => pos_integer,
              optional(:hour) => non_neg_integer,
              optional(:microsecond) => {char, 0 | 1 | 2 | 3 | 4 | 5 | 6},
              optional(:minute) => non_neg_integer,
              optional(:month) => pos_integer,
              optional(:second) => non_neg_integer,
              optional(:std_offset) => integer,
              optional(:time_zone) => binary,
              optional(:utc_offset) => integer,
              optional(:year) => integer,
              optional(:zone_abbr) => binary
            },
          binary
        ) :: binary
  def format_ts(time, format \\ "%F %T %z") do
    time |> Timex.format!(format, :strftime)
  end
end
