include ActionView::Helpers::NumberHelper
class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :price_string, :is_bagel, :is_topping, :is_cc, :is_cheese, :is_meat

  def price_string
    if object.price == 0
      "Free"
    else
      "Add #{number_to_currency(object.price)}"
    end
  end

  def is_bagel
    if object.category == "bagel" || object.category == "variety bagel"
      result = "true"
    end
    result
  end

  def is_topping
    if object.category == "topping"
      result = "true"
    end
    result
  end

  def is_cc
    if object.category == "basic cc" || object.category == "deluxe cc"
      result = "true"
    end
    result
  end

  def is_cheese
    if object.category == "cheese"
      result = "true"
    end
    result
  end

  def is_meat
    if object.category == "meat"
      result = "true"
    end
    result
  end
end
