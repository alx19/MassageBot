class Course
  class Contract < Dry::Validation::Contract
    params do
      required(:title).filled(:string)
      required(:description).filled(:string)
      required(:content).filled(:string)
      required(:price).filled(:integer)
      optional(:files).array(:hash)
    end
  end

  def initialize(params)
    validation_result = Contract.new.call(params)

    if validation_result.success?
      @course_data = OpenStruct.new(params)
    else
      raise ArgumentError, validation_result.errors.to_h
    end
  end

  def title
    @course_data.title
  end

  def description
    @course_data.description
  end

  def content
    @course_data.content
  end

  def price
    @course_data.price
  end

  def files
    @course_data.files&.map { |file_data| OpenStruct.new(file_data) } || []
  end
end
