defmodule SnitchApiWeb.Router do
  use SnitchApiWeb, :router

  alias SnitchApiWeb.Guardian

  pipeline :api do
    plug(:accepts, ["json-api", "json"])
    plug(JaSerializer.Deserializer)
  end

  pipeline :authenticated do
    plug(Guardian.AuthPipeline)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through(:api)
    # user sign_in_up
    post("/register", UserController, :create)
    post("/login", UserController, :login)
    post("/orders/blank", OrderController, :guest_order)
    get("/variants/favorites", VariantController, :favorite_variants)
    resources("/products", ProductController, except: [:new, :edit], param: "product_slug")
    get("/orders/:order_number", OrderController, :fetch_guest_order)
    post("/hosted-payment/payubiz-request", HostedPaymentController, :payubiz_request_url)
    post("/hosted-payment/:source/success", HostedPaymentController, :payment_success)
    post("/hosted-payment/:source/error", HostedPaymentController, :payment_error)
    resources("/taxonomies", TaxonomyController, only: [:index, :show])
    resources("/taxons", TaxonController, only: [:index, :show])
    get("/countries", AddressController, :countries)
    get("/countries/:id/states/", AddressController, :country_states)
    get("/brands", ProductBrandController, :index)
  end

  scope "/api/v1", SnitchApiWeb do
    pipe_through([:api, :authenticated])

    # user sign_in_out_up
    get("/users/:id", UserController, :show)
    get("/authenticated", UserController, :authenticated)
    post("/logout", UserController, :logout)
    get("/current_user", UserController, :current_user)
    resources("/wishlist_items", WishListItemController, only: [:index, :create, :delete])
    resources("/orders", OrderController, only: [:index, :show])
    resources("/line_items", LineItemController, only: [:create, :update, :show])
    delete("/line_items", LineItemController, :delete)
    post("/orders/:id/select_address", OrderController, :select_address)
    post("/orders/:id/add-payment", OrderController, :add_payment)
    post("/orders/current", OrderController, :current)
    resources("/ratings", RatingController, only: [:index, :show])
    resources("/reviews", ReviewController, only: [:create, :update, :delete])
    get("/product/:id/rating-summary", ProductController, :rating_summary)
    get("/product/:id/reviews", ProductController, :reviews)
    resources("/addresses", AddressController, only: [:index, :show, :create, :update])
    get("/payment/payment-methods", PaymentController, :payment_methods)
  end
end
