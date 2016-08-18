;;; Guiloku
;;; Copyright (C) 2016 Frederick M. Muriithi <>
;;;
;;; Guiloku is free software: you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; Guiloku is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;;; See the GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.

(use-modules (guix gexp)
             (guix packages)
             (guix download)
             (guix build-system gnu)
             (guix licenses))

(define guiloku
  (package
   (name "guiloku")
   (version "0.1.0")
   (source (local-file "." #:recursive? #t))
   (build-system gnu-build-system)
   (inputs
    '(("sly" ,sly)))
   (synopsis "Guiloku: A simple game of gomoku, written in Guile")
   (description "Guiloku implements a game of gomoku, allowing 2 players to play against each other on a 15 by 15 board. It is implemented in Guile")
   (license gpl3+)
   (home-page "https://github.com/fredmanglis/guiloku")))
