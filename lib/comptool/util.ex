defmodule CompTool.Util do
  def build_url_with_querystring(url, dict) do
    qs = build_querystring(dict) |> Enum.join
    qs = String.slice(qs, 1, String.length(qs) - 1)
    "#{url}?#{qs}"
  end

  defp build_querystring([]) do
    []
  end
  defp build_querystring([{k, v} | rest]) do
    encoded = binary_to_list(v) |> :edoc_lib.escape_uri |> list_to_binary
    chunk = "&#{k}=#{encoded}"
    [chunk | build_querystring(rest)]
  end
end
