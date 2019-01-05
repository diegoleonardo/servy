defmodule Servy.Conv do
    defstruct method: "", 
              path: "", 
              params: %{},
              headers: %{},
              resp_headers: %{"Content-Type" => "text/html", "Content-Length" => 0},
              resp_body: "", 
              status: nil 

    def full_status(conv) do
       "#{conv.status} #{status_code(conv.status)}"
    end

    defp status_code(code) do
        %{
            200 => "OK",
            201 => "Created",
            401 => "Unauthorized",
            403 => "Forbidden",
            404 => "Not Found",
            500 => "Internal Server Error"
        }[code]
    end

end