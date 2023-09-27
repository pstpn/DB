SELECT
    number, balance, release_date, cards.owner, banks.name
FROM cards
JOIN banks ON cards.bank_id = banks.id
WHERE banks.is_international = true;