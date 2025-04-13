--!strict
--!optimize 2
--!native

-- Types.luau
-- This module defines the types used in the FastNet library.

export type Encoder<T> = (value: T, size: number?) -> ()
export type Decoder<T> = (buf: buffer, cursor: number) -> (T, number?)

export type BufferType<T> = {
    sample: T,
    encoder: Encoder<T>,
    decoder: Decoder<T>,
    size : number?,
}

export type Callback<T...> = (T...) -> ()

export type Signal<A...> = {
    Connect : (callback : Callback<A...>) -> (),
    Once : (callback : Callback<A...>) -> (),
    Wait : () -> (),
    Fire : (A...) -> (),
    Destroy : () -> (),
}

export type Packet<T> = {
    FireServer : (data : T) -> (),
    FireClient : (player : Player, data : T) -> (),
    FireAllClients : (data : T) -> (),
    OnServerEvent : Signal<Player, T>,
    OnClientEvent : Signal<T>,  
}

return nil