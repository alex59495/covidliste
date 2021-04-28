class UluleService
  include HTTParty
  base_uri "https://api.ulule.com"
  format :json

  def initialize(project_id)
    @project_id = project_id
    @api_key = ENV["ULULE_API_KEY"]
    self.class.default_options.merge!(
      headers: {
        "Authorization" => "APIKey #{@api_key}",
        "Ulule-Version" => "2020-11-10"
      }
    )
  end

  def project
    self.class.get("/v1/projects/#{@project_id}")
  end

  def supporters
    self.class.get("/v1/projects/#{@project_id}/supporters", query: {limit: 25})
  end

  def get_supporters(min = 0, max = 0)
    all_orders.select { |x| x["order_total"] >= min && x["order_total"] < max }.map { |x| x["user"] }
  end

  def all_orders
    @all_orders ||= get_all_orders
  end

  def get_all_orders(pagination = 20)
    results = get_orders(pagination)
    all_orders = results["orders"]
    while results["meta"]["next"]
      results = get_orders(pagination, all_orders.size)
      all_orders = all_orders.concat(results["orders"])
    end
    all_orders
  end

  def get_orders(limit, offset = 0)
    self.class.get("/v1/projects/#{@project_id}/orders", query: {limit: limit, offset: offset})
  end
end