defmodule FinanceChain.Services.Utils do
  alias FinanceChain.BlockChain

  def total_amount(%BlockChain{chain: chain}, id) do
    total_amount_for_destination(chain, id) - total_amount_for_origin(chain, id)
  end

  def search(%BlockChain{chain: chain}, id) do
    search_aux(chain, id)
  end

  def search_aux([],_) do
    0
  end

  def search_aux([a | _], id) when a.data.origin == id do
    id
  end

  def search_aux([a | _], id) when a.data.destination == id do
    id
  end

  def search_aux([_ | b], id) do
    search_aux(b, id)
  end




  @spec total_amount_for_origin([map], any) :: number
  def total_amount_for_origin([], _) do
    0
  end

  def total_amount_for_origin([a | b], originID) when a.data.origin == originID do
    a.data.amount + total_amount_for_origin(b, originID)
  end

  def total_amount_for_origin([a | b], originID) when a.data.origin != originID do
    total_amount_for_origin(b, originID)
  end

  def total_amount_for_destination([], _) do
    0
  end

  def total_amount_for_destination([a | b], destinationID)
      when a.data.destination == destinationID do
    a.data.amount + total_amount_for_destination(b, destinationID)
  end

  def total_amount_for_destination([a | b], destinationID)
      when a.data.destination != destinationID do
    total_amount_for_destination(b, destinationID)
  end

  def total_amount_for_origin_and_destination([], _) do
    0
  end

end
