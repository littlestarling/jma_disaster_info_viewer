class FeedsController < ApplicationController
  DATA_DIR     = "#{Rails.root}/tmp/jmx_data"
  VERIFY_TOKEN = "test_verify_token_for_jma_disaster_info_viewer"

  # ignore_protect_from forgery
  skip_before_filter :verify_authenticity_token

  def index
    mode         = params['hub.mode']
    topic        = params['hub.topic']
    challenge    = params['hub.challenge']
    verify_token = params['hub.verify_token']

    # hub.mode チェック
    not_found and return unless mode =~ /subscribe/

    # hub.verify_token チェック
    if verify_token == VERIFY_TOKEN
      # Content-type に "text/plain" を指定し、
      # challenge コードをそのまま返却
      response.headers['Content-Type'] = "text/plain"
      render text: challenge.chomp, status: 200 and return
    else
      not_found and return
    end
  end

  def create
    body = request.body.read

    # ヘッダ HTTP_X_HUB_SIGNATURE の値を取得
    hub_sig = request.env['HTTP_X_HUB_SIGNATURE']

    # HMAC-SHA1 の計算
    sha1 = OpenSSL::HMAC::hexdigest(OpenSSL::Digest::SHA1.new, VERIFY_TOKEN, body)

    logger.info "#### hub_sig = #{hub_sig}"
    logger.info "#### sha1    = #{sha1}"

    # ファイルとして保存
    # 実際は、HTTP_X_HUB_SIGNATURE の値と
    # verigy_token から計算した HMAC-SHA1 が等しい場合のみ処理を行う
    file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}_atom.xml"
    File.open("#{DATA_DIR}#{file_name}", 'wb') { |f| f.write body }
    # TODO: parse data and post data to nadoka.
    render nothing: true, status: 200 and return
  end

  # return 404 with nothing
  def not_found
    render nothing: true, status: 404
  end
end

