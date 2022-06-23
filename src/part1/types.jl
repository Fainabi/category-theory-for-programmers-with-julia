abstract type AbstractFunctor{T} end  # chapter07
abstract type AbstractBifunctor{S, T} <: AbstractFunctor{T} end  # move from chapter08
abstract type AbstractMorphism <: Function end
