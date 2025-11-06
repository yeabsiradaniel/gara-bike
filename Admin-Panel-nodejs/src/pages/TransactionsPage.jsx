import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, Button } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';

const TransactionsPage = () => {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [transactionToDelete, setTransactionToDelete] = useState(null);

  const fetchTransactions = () => {
    setLoading(true);
    dataService.getAll('transactions')
      .then(response => {
        setTransactions(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch transactions:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchTransactions();
  }, []);

  const handleDeleteClick = (id) => {
    setTransactionToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('transactions', transactionToDelete);
      fetchTransactions(); // Re-fetch data
      setDeleteDialogOpen(false);
      setTransactionToDelete(null);
    } catch (error) {
      console.error("Failed to delete transaction:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'Transaction ID', width: 220 },
    { field: 'wallet', headerName: 'User', width: 220, valueGetter: (value) => value.user.email },
    { field: 'amount', headerName: 'Amount', type: 'number', width: 100 },
    { field: 'transaction_type', headerName: 'Type', width: 150 },
    { field: 'description', headerName: 'Description', width: 250 },
    { field: 'timestamp', headerName: 'Date', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 100,
      getActions: ({ id }) => [
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Manage Transactions</Typography>
      <DataGrid
        rows={transactions}
        columns={columns}
        loading={loading}
        getRowId={(row) => row._id}
        initialState={{          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
      >
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete this transaction? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default TransactionsPage;