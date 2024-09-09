module WebHelper
  def json_error_response(status, message)
    [status, { 'content-type' => 'application/json' }, [{ error: message }.to_json]]
  end
end