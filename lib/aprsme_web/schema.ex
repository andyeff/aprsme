defmodule AprsmeWeb.Schema do
  use Absinthe.Schema
  #import Absinthe.Resolution.Helpers
  import_types Absinthe.Type.Custom
  import_types AprsmeWeb.Schema.Types

  query do
    field :hello, :string do
      resolve fn _, _ -> {:ok, "world!"} end
    end

    # @desc "Get a list of Packets"
    # field :packet, list_of(:packet) do
    #   resolve &AprsmeWeb.PacketResolver.all/2
    # end

    field :packet, type: :packet do
      arg :id, :integer
      arg :srccallsign, :string
      resolve &AprsmeWeb.PacketResolver.find/2
    end
  end
end