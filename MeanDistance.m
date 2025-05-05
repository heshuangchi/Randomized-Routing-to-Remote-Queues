clear;

numCustomers = 1e8;

delta = 1;

sum = 0;
counter = 0;

LocationX = rand(numCustomers, 1)*200;
LocationY = rand(numCustomers, 1)*200;

delay(1, :) = sqrt((LocationX - 50).^2 + (LocationY - 50).^2);
delay(2, :) = sqrt((LocationX - 50).^2 + (LocationY - 150).^2);
delay(3, :) = sqrt((LocationX - 150).^2 + (LocationY - 50).^2);
sort_delay = sort(delay, 'ascend');

for jj = 1:numCustomers
    if sort_delay(2, jj) - sort_delay(1, jj) < delta
        sum = sum + sort_delay(1, jj);
        counter = counter + 1;
    end
end

sum/counter
