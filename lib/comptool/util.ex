defmodule CompTool.Util do
  def json_response(data, status_code // 200, req) do
    :cowboy_req.reply(
      status_code, [{"content-type", "application/json"}],
      :jsx.encode(data), req
    )
  end

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

  def string_dict_to_kw_list([]) do
    []
  end
  def string_dict_to_kw_list([{k, v} | rest]) when is_bitstring(k) do
    if is_list(v) do
      v = try do
        string_dict_to_kw_list(v)
      catch
        _ -> v
      end
    end
    [{binary_to_atom(k), v} | string_dict_to_kw_list(rest)]
  end
  def string_dict_to_kw_list([x | rest]) do
    [string_dict_to_kw_list(x) | string_dict_to_kw_list(rest)]
  end
  def string_dict_to_kw_list(x) do
    x
  end
end
